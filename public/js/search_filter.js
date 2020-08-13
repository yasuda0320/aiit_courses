$(document).ready(function () {
    let filterTag = [];
    let unFilterTag = [];

    $("#SearchInput").on("keyup", function () {
        var value = $(this).val().toLowerCase();
        $("table tbody tr").filter(function () {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
        if (filterTag.length > 0) {
            $('input:checkbox[name="sspt[]"]').change();
        } else {
            $("table tbody tr:visible").each(function (index, item) {
                unFilterTag.forEach(function (val, index, arr) {
                    item.children[val].setAttribute('style', 'color:#000000');
                })
            });
        }
    });

    $('input:checkbox[name="sspt[]"]').on("change", function () {
        filterTag = [];
        unFilterTag = [];

        let searchValue = $("#SearchInput").val().toLowerCase();
        let domTrArray;

        if ($.trim(searchValue) != "") {
            $("#SearchInput").keyup();
            domTrArray = $("table tbody tr:visible");
        } else {
            domTrArray = $("table tbody tr");
        }

        $("input[type='checkbox']").each(function (index, item) {
            if (!$(this).prop("checked")) {
                unFilterTag.push($(this).val());
            } else {
                filterTag.push($(this).val());
            }
        });
        if (filterTag.length < 1) {
            if ($.trim(searchValue) != "") {
                $("#SearchInput").keyup()
            } else {
                $("table tbody tr").show().each(function (index, item) {
                    unFilterTag.forEach(function (val, index, arr) {
                        item.children[val].setAttribute('style', 'color:#000000');
                    })
                });
            }
        } else {
            domTrArray.hide().each(function (index, item) {
                filterTag.forEach(function (val, index, arr) {
                    if (item.children[val].textContent.indexOf("◎") > -1) {
                        item.removeAttribute("style");
                        item.children[val].setAttribute('style', 'color:#ff9966');
                    }
                });
                unFilterTag.forEach(function (val, index, arr) {
                    item.children[val].setAttribute('style', 'color:#000000');
                })
            })
        }
    });

    $("#Clear").on("click", function () {
        $("#SearchInput").val('');
        $('input:checkbox[name="sspt[]"]').each(function () {
            $(this).prop("checked", false);
        });
        $('input:checkbox[name="sspt[]"]').change();
    });
});